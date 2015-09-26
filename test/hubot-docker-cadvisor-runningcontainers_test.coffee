#https://amussey.github.io/2015/08/11/testing-hubot-scripts.html
Helper = require('hubot-test-helper')
fs = require 'fs'
expect = require('chai').expect
nock = require 'nock'
# helper loads a specific script if it's a file
helper = new Helper('../src/hubot-docker-cadvisor-V1_3.coffee')


describe 'Test the running containers methode', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    do nock.disableNetConnect

  afterEach ->
    # Tear it down after the test to free up the listener.
    room.destroy()
    nock.cleanAll()

  context 'user says cadvisor list short, one container is running', ->
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor list short'
      setTimeout done, 100
      
    it 'should reply a list with one running container message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor list short']
        ['hubot', '[1] cadvisor_cadvisor_1 http://localhost:7076/docker/7171f464213672faa2be61d4ca5a3af0d5988024a3fdb61ec8aa223ceefe71ae\n']
      ]
      
  context 'user says cadvisor list short, four container are running', ->
    goldenFileMessage = fs.readFileSync __dirname+'/goldenfile/responseContainersShort-multi.message'
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers-multi.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor list short'
      setTimeout done, 100
      
    it 'should reply a list of four running container message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor list short']
        ['hubot', ((goldenFileMessage).toString()) ]
      ]      

# cadvisor list details Test methods

  context 'user says cadvisor list details, one container is running', ->
    goldenFileMessage = fs.readFileSync __dirname+'/goldenfile/responseContainerDetails.message'
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor list details'
      setTimeout done, 100
      
    it 'should reply a list with one running container message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor list details']
        ['hubot', ((goldenFileMessage).toString()) ]
      ]      

  context 'user says cadvisor aggregated details, one container is running', ->
    goldenFileMessage = fs.readFileSync __dirname+'/goldenfile/responseContainerAggregatedDetails.message'
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor aggregated details'
      setTimeout done, 100
      
    it 'should reply a list with one running container message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor aggregated details']
        ['hubot', ((goldenFileMessage).toString()) ]
      ]      

  context 'user says cadvisor aggregated details, one container is running', ->
    goldenFileMessage = fs.readFileSync __dirname+'/goldenfile/responseContainerAggregatedDetails-multi.message'
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers-multi.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor aggregated details'
      setTimeout done, 100
      
    it 'should reply a list with one running container message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor aggregated details']
        ['hubot', ((goldenFileMessage).toString()) ]
      ]      
                  