`import DS from 'ember-data'`

ApplicationAdapter = DS.RESTAdapter.extend
  host: 'http://angulartododemo.azurewebsites.net'
  namespace: 'api'

`export default ApplicationAdapter`
