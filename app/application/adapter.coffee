`import DS from 'ember-data'`

ApplicationAdapter = DS.RESTAdapter.extend
  host: 'https://angulartododemo.azurewebsites.net'
  namespace: 'api'

`export default ApplicationAdapter`
