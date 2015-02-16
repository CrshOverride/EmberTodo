`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend(
  location: config.locationType
)

Router.map(->
  @.route('todos', path: '/')
  @.route('login')
  @.route('signup')
)

`export default Router`
