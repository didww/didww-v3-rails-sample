import onmount from 'onmount'
import remoteForm from "../includes/remote_form";
import createElement from '../includes/create_element'

onmount('#requirement-validation-modal', function() {
    const requirementValidationModal = $('#requirement-validation-modal')
    const form = requirementValidationModal.find('form')

    requirementValidationModal.on('hidden.bs.modal', function(){
        form[0].reset()
        form.find('div.alert').remove()
        form.find('ul.errors').remove()
    })

    remoteForm(
        form,
        'requirement-validation',
        null,
        {
            onSuccess: function (form, data) {
                form.prepend(
                    createElement('div', { class: 'alert alert-success' }, `${data.message}`)
                )
            }
        }
    )
})
