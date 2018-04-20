module.exports = function (environment) {
  environment.loaders.prepend('eslint', {
    enforce: 'pre',
    test: /\.(js|jsx)$/i,
    exclude: /node_modules/,
    loader: 'eslint-loader',
    options: {
      failOnError: true
    }
  })
  return environment
}
