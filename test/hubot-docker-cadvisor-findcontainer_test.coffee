#https://amussey.github.io/2015/08/11/testing-hubot-scripts.html
Helper = require('hubot-test-helper')
fs = require 'fs'
expect = require('chai').expect
nock = require 'nock'
# helper loads a specific script if it's a file
helper = new Helper('../src/hubot-docker-cadvisor-V1_3.coffee')


describe 'Test to find one running container', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    do nock.disableNetConnect

  afterEach ->
    # Tear it down after the test to free up the listener.
    room.destroy()
    nock.cleanAll()

  context 'user says cadvisor info container cadvisor_cadvisor_1, the container is existing', ->
    goldenFileMessage = fs.readFileSync __dirname+'/goldenfile/responseContainerInfoCAdvisor.message'
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor info container cadvisor_cadvisor_1'
      setTimeout done, 100
      
    it 'should reply a container details message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor info container cadvisor_cadvisor_1']
        ['hubot', ((goldenFileMessage).toString())]
      ]
      
  context 'user says cadvisor info container not_exist_1, the container not exist', ->
    goldenFileMessage = fs.readFileSync __dirname+'/goldenfile/responseContainerInfoCAdvisor.message'
    beforeEach (done) ->
      containersMockJsonResponse = fs.readFileSync __dirname+'/fixdata/V1.3/subcontainers.json'
      nock('http://localhost:8080').get('/api/v1.3/subcontainers').reply(200,containersMockJsonResponse )
      room.user.say 'alice', 'hubot cadvisor info container not_exist_1'
      setTimeout done, 100
      
    it 'should reply a container details message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor info container not_exist_1']
        ['hubot', 'Sorry i can`t located not_exist_1!']
      ]
      
                                    