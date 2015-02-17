module.exports = function(grunt) {
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    shell: {
      build: {
        command: 'ember build -prod',
        options: {
          stdout: true,
          stdin: false
        }
      },
      test: {
        command: 'ember test',
        options: {
          stdout: true,
          stdin: false
        }
      }
    }
  });

  grunt.registerTask('default', ['shell:build'])
}
