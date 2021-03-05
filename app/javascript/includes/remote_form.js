const ERROR_CONTAINER_CLASS = 'div_with_error'
const ERROR_MESSAGE_CLASS = 'inline-errors'

function createElement(tagName, attributes, children) {
    var text = attributes.text
    delete attributes.text
    var node = $('<' + tagName + '>', attributes)
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
    var words = text.split(separator || '_')
    var result = words.map(function (part, index) {
        return (onlyFirstUpper && index !== 0) ? part : capitalizeWord(part)
    })
    return result.join(' ')
}

function clearFormFieldErrors(form) {
    form.find('p.' + ERROR_MESSAGE_CLASS).remove()
    form.find('div.' + ERROR_CONTAINER_CLASS).removeClass(ERROR_CONTAINER_CLASS)
}

function calcFieldName(rootName, errorName) {
    var fieldName = errorName
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

    var errorMessage = errorMessages.join(', ')
    if (!errorMessage) {
        return
    }

    var input = form.find(
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

    var inputContainer = input.parent()
    inputContainer.addClass(ERROR_CONTAINER_CLASS)
    inputContainer.append(
        createElement('p', { class: ERROR_MESSAGE_CLASS, style: 'display: block', text: errorMessage })
    )
}

function clearSemanticErrors(form) {
    form.children('ul.errors').remove()
    form.children('.base-errors').remove()
}

function setSemanticErrors(form, errorMessages) {
    clearSemanticErrors(form)
    if (!errorMessages) {
        return
    }

    var node = createElement(
        'div',
        { class: 'base-errors' },
        createElement('ul', { class: 'errors' })
    )
    form.prepend(node)

    var container = form.find('.base-errors .errors')
    errorMessages.forEach(function (msg) {
        container.append(
            createElement('li', { text: msg })
        )
    })
}

function applyFormSemanticErrors(form, errors) {
    var errorLines = []

    Object.keys(errors).forEach(function (errorName) {
        var errorMessage = errors[errorName].join(', ')
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
        var value = fields[inputName]
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
    var submitBtn = form.find('input[type="submit"]')
    submitBtn.removeAttr('disabled')
    submitBtn.removeClass('disabled')
}

function disableSubmitBtn(form) {
    var submitBtn = form.find('input[type="submit"]')
    submitBtn.attr('disabled', 'disabled')
    submitBtn.addClass('disabled')
}

function remoteForm(form, rootName, fields) {
    form.submit(function () {
        // event.preventDefault()
        disableSubmitBtn(form)
        clearFormFieldErrors(form)
        clearSemanticErrors(form)

        var formData = new FormData(form[0])
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
        }).done(function () {
            // enableSubmitBtn(form)
            // window.location = response.responseJSON.redirect_uri
        }).fail(function (response) {
            // console.log('remoteForm initializeForm ajax.fail', response)
            enableSubmitBtn(form)
            if (response.status === 422) {
                var errors = response.responseJSON.errors
                // console.log('submit 422', errors)
                applyFormSemanticErrors(form, errors)
                Object.keys(errors).forEach(function (errorName) {
                    var fieldName = calcFieldName(rootName, errorName)
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
