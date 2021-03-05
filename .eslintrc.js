module.exports = {
    env: {
        browser: true,
        es2021: true,
        jquery: true
    },
    extends: [
        'airbnb-base',
    ],
    parserOptions: {
        ecmaVersion: 12,
        sourceType: 'module',
    },
    rules: {
        indent: ['error', 4],
        quotes: ["error", "double"],
        semi: ["error", "never"],
        "comma-dangle": ["error", "never"],
        "func-names": ['off'],
        "consistent-return": ['off']
    }
};
