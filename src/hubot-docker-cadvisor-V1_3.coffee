# Description:
#   hubot Script for cadvisor API 1.3 communication
#   Cadvisor API Doc: https://github.com/google/cadvisor/blob/master/docs/api.md  
#
# Commands:
#   hubot cadvisor ping - ping the cadvisor host
#   hubot cadvisor list short - list all running containers
#   hubot cadvisor list details - list all running containers with detail information
#   hubot cadvisor aggregated details - Display aggregated Container Information
#   hubot cadvisor info container <container label> - display container details
#
# Notes:
#   CADVISOR_URL=http://cadvisorhost:8080/api/v1.3
#   CADVISOR_PUBLIC_URL=http://localhost:7076/docker
#   
# Author:
#  nolte07
#

utilformatting = require('./formattingutils')

cadvisorurl = process.env.CADVISOR_URL ? 'http://localhost:8080/api/v1.3'
cadvisorPublicUrl = process.env.CADVISOR_PUBLIC_URL ? 'http://localhost:7076/docker'

buildHttpStatusMessage = (res) ->
  message ="Sorry can`t connect to host, Http Status (#{res.statusCode})\n"
  message +="API Url:\t#{cadvisorurl}"
  message
  
buildShortContainersListMessage = (containers) ->
  index = 0
  message =""
  for container in containers
    do (container) ->  
      index += 1
      containerUrl = cadvisorPublicUrl + '/' + container.aliases[1]
      message += "[#{index}] #{container.aliases[0]} #{containerUrl}\n"
  message 

buildAggeregateDetailsMessage = (containers) ->
  infos =
    containerCount: 0  
    memoryUsage: 0
  
  for container in containers
    do (container) ->
      infos.containerCount += 1
      infos.memoryUsage +=  container.memoryAverage
      
  message =  "Containers Count:\t#{infos.containerCount}\n"
  formattedMemory = utilformatting.prettyFileSize(infos.memoryUsage)
  message +=  "Containers Memory:\t#{utilformatting.prettyFileSize(infos.memoryUsage)}"
  message          


buildDetailsContainersListMessage = (containers) ->
  index = 0
  message =""
  for container in containers
    do (container) ->  
      index += 1
      containerUrl = cadvisorPublicUrl + '/' + container.aliases[1]
      formattedMemory = utilformatting.prettyFileSize(container.memoryAverage)
      message += "=========[#{index}]=========\n"
      message += "Container Label:\t#{container.aliases[0]}\n"
      message += "Container Id:\t#{container.aliases[1]}\n"
      message += "Container Url:\t#{containerUrl}\n"
      message += "Docker Project:\t#{container.spec.labels['com.docker.compose.project']}\n"
      message += "Docker Service:\t#{container.spec.labels['com.docker.compose.service']}\n"
      message += "Docker Version:\t#{container.spec.labels['com.docker.compose.version']}\n"
      message += "Docker Config:\t#{container.spec.labels['com.docker.compose.config-hash']}\n"
      message += "Creation Time:\t#{container.spec.creation_time}\n"
      message += "Memory Usage:\t#{formattedMemory}"
  
  message


ping =  (robot,callback) ->
  robot.http(cadvisorurl)
    .header('Accept', 'application/json')
    .get() (err, res, body) ->
      return callback(err or res ) if err or res.statusCode < 200 or res.statusCode >= 300
      callback(err,true)


findRunningContainer = (robot, containerLabel, callback) ->
   loadRunningContainers robot,(error, dockerContainers) ->
      return msg.send buildHttpStatusMessage(error) unless dockerContainers
      matchingContainer = (match for match in dockerContainers when match.aliases[0] == containerLabel)
      callback(error,matchingContainer)


loadRunningContainers = (robot,callback) ->
  robot.http(cadvisorurl+'/subcontainers')
    .header('Accept', 'application/json')
    .get() (err, res, body) ->
      return callback(err or res ) if err or res.statusCode < 200 or res.statusCode >= 300
      allContainers = JSON.parse(body)
      
      dockerContainerList = []
      
      for container in allContainers
         do (container) ->
           # check existing Attribute 'namespace' to find the running containers. 
           dockerContainerList.push container if container.namespace?

      for container in dockerContainerList
         do (container) ->
           sumMemoryUsage=0
           for stat in container.stats
             do (stat) ->
               sumMemoryUsage += stat.memory.usage
               
           container.memoryAverage = sumMemoryUsage
      
      callback(err,dockerContainerList)     
 
module.exports = (robot) ->
  robot.respond /cadvisor info container (.*)/i, (msg) ->
    containerLabel = msg.match[1]
    findRunningContainer robot,containerLabel,(error, body) ->
      return msg.send "not found" unless body
      return msg.send "Sorry i can`t located #{containerLabel}!" if body.length == 0  
      
      msg.send buildDetailsContainersListMessage(body)
    

  robot.respond /cadvisor aggregated details/i, (msg) ->
    loadRunningContainers robot,(error, body) ->
      return msg.send buildHttpStatusMessage(error) unless body
      
      msg.send buildAggeregateDetailsMessage(body)
 

  robot.respond /cadvisor list details/i, (msg) ->
    console.log "cadvisor list details container list"
    loadRunningContainers robot,(error, body) ->
      return msg.send buildHttpStatusMessage(error) unless body
      
      msg.send buildDetailsContainersListMessage(body)
      
  robot.respond /cadvisor list short/i, (msg) ->
    console.log "cadvisor list short container list"
    loadRunningContainers robot,(error, body) ->
      return msg.send buildHttpStatusMessage(error) unless body
      
      msg.send buildShortContainersListMessage(body)

  robot.respond /cadvisor ping/i, (msg) ->
    console.log "cadvisor ping"
    ping robot,(error, body) ->
      return msg.send buildHttpStatusMessage(error) unless body
      message = "Successful connect to cadvisor host\n" 
      message += "WebUI Url:\t#{cadvisorPublicUrl}\n"
      message += "API Url:\t#{cadvisorurl}"
      msg.send message

  robot.cadvisor = {
    ping: ping,
    findRunningContainer: findRunningContainer,
    loadRunningContainers: loadRunningContainers
  }      