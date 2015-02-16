`import Ember from 'ember'`
`import ApplicationRouteMixin from 'simple-auth/mixins/application-route-mixin'`

ApplicationRoute = Ember.Route.extend ApplicationRouteMixin,
  actions:
    sessionAuthenticationFailed: (error) ->
      @controllerFor('login').set('login_error_message', 'Oh noes! You broke teh Interwebs wit ur creds. Try again!')

    authorizationFailed: (error) ->
      @controllerFor('login').set('login_error_message', 'Oh noes! You broke teh Interwebs wit ur creds. Try again!')

`export default ApplicationRoute`
