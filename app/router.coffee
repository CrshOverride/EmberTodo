`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend(
  location: config.locationType
)

Router.map(->
  @.route('todo', path: '/')
  @.route('login')
)

`export default Router`
