`import Ember from 'ember'`
`import ApplicationRouteMixin from 'simple-auth/mixins/application-route-mixin'`

ApplicationRoute = Ember.Route.extend ApplicationRouteMixin,
  actions:
    error: (error, transition) ->
      @get('session').invalidate() if error.status in [401, 0]

    authorizationFailed: (error) ->
      Ember.Logger.debug("authorizationFailed")
      @controllerFor('login').set('login_error_message', 'Oh noes! You broke teh Interwebs wit ur creds. Try again!')

`export default ApplicationRoute`
