import attachRemoteForm from '../includes/attach_fill_documents_form'
import onmount from "onmount";

onmount('#add-permanent-document-modal', function() {
    const addPermanentDocumentModal = $('#add-permanent-document-modal')
    attachRemoteForm(addPermanentDocumentModal.find('form'), 'permanent-supporting-document')
    addPermanentDocumentModal.on('hidden.bs.modal', function () {
        const form = addPermanentDocumentModal.find('form')
        form[0].reset()
        form.find('.encrypted-file-input').trigger('change')
    })
})

onmount('#replace-permanent-document-modal', function () {
    const replacePermanentDocumentModal = $('#replace-permanent-document-modal')
    attachRemoteForm(replacePermanentDocumentModal.find('form'), 'permanent-supporting-document')
    replacePermanentDocumentModal.on('shown.bs.modal', function (event) {
        const templateName = $(event.relatedTarget).attr('data-permanent-document-template-name')
        const templateId = $(event.relatedTarget).attr('data-permanent-document-template-id')
        const form = $(event.currentTarget).find('form')
        if (templateName) form.find('.permanent-document-template-label').text(templateName)
        if (templateId) form.find('.permanent-document-template-input').val(templateId)
    })
    replacePermanentDocumentModal.on('hidden.bs.modal', function () {
        const form = replacePermanentDocumentModal.find('form')
        form.find('.permanent-document-template-label').text('')
        form[0].reset()
        form.find('.permanent-document-template-input').trigger('change')
    })
})
