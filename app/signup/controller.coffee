`import Ember from 'ember'`

SignupController = Ember.Controller.extend
  actions:
    signup: ->
      request = new Ember.RSVP.Promise((resolve, reject) =>
        Ember.$.ajax(
          url: 'http://angulartododemo.azurewebsites.net/add-user'
          type: 'POST'
          dataType: 'json'
          data:
            email: @get('email')
            password: @get('password')
          success: (response) -> resolve(response)
          error: (reason) -> reject(reason)
        )
      )

      request
        .then(=> @transitionTo('login'))
        .catch((reason) =>
          @set('signup_error_message', reason.responseJSON.message.message)
        )

`export default SignupController`
