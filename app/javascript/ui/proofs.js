import attachRemoteForm from '../includes/attach_fill_documents_form'
import onmount from 'onmount'

onmount('#add-proof-modal', function() {
    const addProofModal = $('#add-proof-modal')
    attachRemoteForm(addProofModal.find('form'), 'proof')
    addProofModal.on('hidden.bs.modal', function () {
        const form = addProofModal.find('form')
        form[0].reset()
        form.find('.encrypted-file-input').trigger('change')
    })
})

onmount('#replace-proof-modal', function () {
    const replaceProofModal = $('#replace-proof-modal')
    attachRemoteForm(replaceProofModal.find('form'), 'proof')
    replaceProofModal.on('shown.bs.modal', function (event) {
        const proofTypeName = $(event.relatedTarget).attr('data-proof-type-name')
        const proofTypeId = $(event.relatedTarget).attr('data-proof-type-id')
        const form = $(event.currentTarget).find('form')
        if (proofTypeName) form.find('.proof-type-label').text(proofTypeName)
        if (proofTypeId) form.find('.proof-type-input').val(proofTypeId)
    })
    replaceProofModal.on('hidden.bs.modal', function () {
        const form = replaceProofModal.find('form')
        form.find('.proof-type-label').text('')
        form[0].reset()
        form.find('.encrypted-file-input').trigger('change')
    })
})
