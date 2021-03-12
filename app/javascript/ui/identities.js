import encryptFilesManager from "../includes/encrypt_file"
import remoteForm from "../includes/remote_form"
import createElement from '../includes/create_element'
import onmount from 'onmount'

function inputSetState(input, text) {
    // console.log('inputSetState', input, text)
    let status = input.siblings('.file-input-status')
    if (status.length === 0) {
        input.parent().append(
            createElement('span', { class: 'file-input-status' })
        )
        status = input.siblings('.file-input-status').css({ marginLeft: '5px' })
    }

    status.html('')
    status.text(text)
}

function attachRemoteForm(form) {
    const filesManager = encryptFilesManager({
        onEmpty: function (input) {
            inputSetState(input, '')
        },
        onEncryptionStart: function (input) {
            inputSetState(input, 'Encrypting...')
        },
        onEncryptionEnd: function (input) {
            inputSetState(input, 'Encrypted.')
        }
    })

    let fileInput = form.find('.encrypted-file-input')
    filesManager.addInput(fileInput)
    filesManager.setFingerprint(form)

    remoteForm(
        form,
        'proof',
        function () {
            console.log(filesManager.encryptedFiles)
            return filesManager.encryptedFiles
        }
    )
}

onmount('#add-proof-modal', function() {
    const addProofModal = $('#add-proof-modal')
    attachRemoteForm(addProofModal.find('form'))
    addProofModal.on('hidden.bs.modal', function () {
        const form = addProofModal.find('form')
        form[0].reset()
        form.find('.encrypted-file-input').trigger('change')
    })
})

onmount('#replace-proof-modal', function () {
    const replaceProofModal = $('#replace-proof-modal')
    attachRemoteForm(replaceProofModal.find('form'))
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
