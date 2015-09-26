#https://amussey.github.io/2015/08/11/testing-hubot-scripts.html
Helper = require('hubot-test-helper')
expect = require('chai').expect
nock = require 'nock'
# helper loads a specific script if it's a file
helper = new Helper('../src/hubot-docker-cadvisor-V1_3.coffee')

describe 'ping', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    do nock.disableNetConnect

  afterEach ->
    # Tear it down after the test to free up the listener.
    room.destroy()
    nock.cleanAll()

  context 'user says ping cadvisor to hubot', ->
    beforeEach (done) ->
      nock('http://localhost:8080').get('/api/v1.3').reply(200)
      room.user.say 'alice', 'hubot cadvisor ping'
      setTimeout done, 100
      
    it 'should reply a successfull connect message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor ping']
        ['hubot', 'Successful connect to cadvisor host\nWebUI Url:\thttp://localhost:7076/docker\nAPI Url:\thttp://localhost:8080/api/v1.3']
      ]

      
  context 'user says ping cadvisor Http Status 404', ->
    beforeEach (done) ->
      nock('http://localhost:8080').get('/api/v1.3').reply(404)
      room.user.say 'alice', 'hubot cadvisor ping'
      setTimeout done, 100
      
    it 'should reply a faild connect message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor ping']
        ['hubot', 'Sorry can`t connect to host, Http Status (404)\nAPI Url:\thttp://localhost:8080/api/v1.3']
      ]
  
  context 'user says ping cadvisor Http Status 501', ->
    beforeEach (done) ->
      nock('http://localhost:8080').get('/api/v1.3').reply(501)
      room.user.say 'alice', 'hubot cadvisor ping'
      setTimeout done, 100
      
    it 'should reply a faild connect message to user', ->
      expect(room.messages).to.eql [
        ['alice', 'hubot cadvisor ping']
        ['hubot', 'Sorry can`t connect to host, Http Status (501)\nAPI Url:\thttp://localhost:8080/api/v1.3']
      ]              