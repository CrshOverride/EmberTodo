`import Ember from 'ember'`
`import LoginControllerMixin from 'simple-auth/mixins/login-controller-mixin'`

LoginController = Ember.Controller.extend LoginControllerMixin,
  authenticator: 'simple-auth-authenticator:token'

`export default LoginController`
