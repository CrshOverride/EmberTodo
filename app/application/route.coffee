`import Ember from 'ember'`
`import ApplicationRouteMixin from 'simple-auth/mixins/application-route-mixin'`

ApplicationRoute = Ember.Route.extend ApplicationRouteMixin,
  actions:
    error: (error, transition) ->
      Ember.Logger.debug(error.toString())
      Ember.Logger.debug("Error Status Code: #{error.statusCode().toString()}")
      @get('session').invalidate() if error.statusCode() is 401

    authorizationFailed: (error) ->
      Ember.Logger.debug("authorizationFailed")
      @controllerFor('login').set('login_error_message', 'Oh noes! You broke teh Interwebs wit ur creds. Try again!')

`export default ApplicationRoute`
π
