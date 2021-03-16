import encryptFilesManager from "../includes/encrypt_file"
import remoteForm from "../includes/remote_form"
import createElement from '../includes/create_element'

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

function attachRemoteForm(form, rootName) {
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
        rootName,
        function () {
            console.log(filesManager.encryptedFiles)
            return filesManager.encryptedFiles
        }
    )
}

export default attachRemoteForm
