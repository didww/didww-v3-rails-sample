process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const applyEslintLoader = require('./loaders/eslint')

applyEslintLoader(environment)

module.exports = environment.toWebpackConfig()
