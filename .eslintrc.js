module.exports = {
  root: true,
  parserOptions: {
    parser: 'babel-eslint'
  },
  env: {
    browser: true,
    jquery: true
  },
  extends: "airbnb-base",
  rules: {
    // don't require .vue extension when importing
    'import/extensions': ['error', 'always', {
      js: 'never'
    }],
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    // no semicolon at the end
    'semi': ['error', 'never'],
    "comma-dangle": ["error", {
      "arrays": "never",
      "objects": "never",
      "imports": "never",
      "exports": "never",
      "functions": "never"
    }],
    'no-alert': 'off',
    'func-names': 'off'
  }
};
