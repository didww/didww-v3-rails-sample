const ERROR_CONTAINER_CLASS = 'has-error'
const ERROR_MESSAGE_CLASS = 'inline-errors'

function createElement(tagName, attributes, children) {
    const text = attributes.text
    delete attributes.text
    const node = $('<' + tagName + '>', attributes)
    if (text) {
        node.text(text)
    }
    if (children) {
        if (!Array.isArray(children)) {
            children = [children]
        }
        children.forEach(function (child) {
            node.append(child)
        })
    }
    return node[0].outerHTML
}

function capitalizeWord(word) {
    return word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase()
}

function humanize(text, separator, onlyFirstUpper) {
    const words = text.split(separator || '_')
    const result = words.map(function (part, index) {
        return (onlyFirstUpper && index !== 0) ? part : capitalizeWord(part)
    })
    return result.join(' ')
}

function clearFormFieldErrors(form) {
    form.find('p.' + ERROR_MESSAGE_CLASS).remove()
    form.find('div.' + ERROR_CONTAINER_CLASS).removeClass(ERROR_CONTAINER_CLASS)
}

function calcFieldName(rootName, errorName) {
    const fieldName = errorName
        .split('/')
        .map(function (part) {
            return '[' + part + ']'
        }).join('')
    return rootName + fieldName
}

function applyFormFieldErrors(form, inputName, fieldName, errorMessages) {
    // console.log('applyFormFieldErrors', inputName, fieldName, errorMessages)
    if (fieldName === 'base') {
        return
    }

    const errorMessage = errorMessages.join(', ')
    if (!errorMessage) {
        return
    }

    const input = form.find(
        [
            'input[name="' + inputName + '"]',
            'select[name="' + inputName + '"]',
            'input[data-name="' + inputName + '"]',
            'select[data-name="' + inputName + '"]',
            'input[type="file"][data-name="' + inputName + '"]'
        ].join(', ')
    )
    addFormFieldError(input, errorMessage)
}

function addFormFieldError(input, errorMessage) {
    if (input.length === 0 || !errorMessage) {
        return
    }

    const inputContainer = input.parent()
    inputContainer.addClass(ERROR_CONTAINER_CLASS)
    inputContainer.append(
        createElement('p', { class: ERROR_MESSAGE_CLASS, style: 'display: block' }, errorMessage)
    )
    // console.log('add field error', input[0], inputContainer[0])
}

function clearSemanticErrors(form) {
    let errorsContainer = form.find('.errors-container')
    if (errorsContainer.length === 0) errorsContainer = form
    errorsContainer.children('ul.errors').remove()
}

function setSemanticErrors(form, errorMessages) {
    clearSemanticErrors(form)
    if (!errorMessages) {
        return
    }

    const node = createElement('ul', { class: 'errors' })
    let errorsContainer = form.find('.errors-container')
    if (errorsContainer.length === 0) errorsContainer = form
    errorsContainer.prepend(node)

    const container = form.find('ul.errors')
    errorMessages.forEach(function (msg) {
        container.append(
            createElement('li', {}, msg)
        )
    })
}

function applyFormSemanticErrors(form, errors) {
    const errorLines = []

    Object.keys(errors).forEach(function (errorName) {
        const errorMessage = errors[errorName].join(', ')
        if (!errorMessage) {
            return
        }

        if (errorName === 'base') {
            errorLines.push(errorMessage)
        } else {
            errorLines.push(
                humanize(errorName.replace('.', '_'), '_', true) + ' ' + errorMessage
            )
        }
    })
    if (errorLines.length === 0) {
        return
    }

    setSemanticErrors(form, errorLines)
}

function addFieldsToFormData(formData, fields) {
    Object.keys(fields).forEach(function (inputName) {
        const value = fields[inputName]
        if (Array.isArray(value)) {
            value.forEach(function (val) {
                formData.append(inputName + '[]', val)
            })
        } else {
            formData.append(inputName, value)
        }
    })
}

function enableSubmitBtn(form) {
    const submitBtn = form.find('input[type="submit"], button[type="submit"]')
    submitBtn.removeAttr('disabled')
}

function disableSubmitBtn(form) {
    const submitBtn = form.find('input[type="submit"], button[type="submit"]')
    submitBtn.attr('disabled', 'disabled')
}

function remoteForm(form, rootName, fields, options) {
    if (!options) options = {}

    form.submit(function () {
        // event.preventDefault()
        disableSubmitBtn(form)
        clearFormFieldErrors(form)
        clearSemanticErrors(form)
        if (options.beforeSubmit) options.beforeSubmit(form)

        const formData = new FormData(form[0])
        if (fields) {
            addFieldsToFormData(formData, fields())
        }

        $.ajax({
            url: form.attr('action'),
            method: form.data('method') || 'POST',
            enctype: 'multipart/form-data',
            processData: false, //Important!
            contentType: false,
            cache: false,
            data: formData
        }).done(function (data) {
            if (options.onSuccess) options.onSuccess(form, data)
            // enableSubmitBtn(form)
            // window.location = response.responseJSON.redirect_uri
        }).fail(function (response) {
            if (options.onError) options.onFailed(form, response)
            // console.log('remoteForm initializeForm ajax.fail', response)
            enableSubmitBtn(form)
            if (response.status === 422) {
                const errors = response.responseJSON.errors
                // console.log('submit 422', errors)
                applyFormSemanticErrors(form, errors)
                Object.keys(errors).forEach(function (errorName) {
                    const fieldName = calcFieldName(rootName, errorName)
                    applyFormFieldErrors(form, fieldName, errorName, errors[errorName])
                })
                return
            }
            console.error(response)
            setSemanticErrors(form, ['Something went wrong'])
        })

        return false
    })
}

export default remoteForm
