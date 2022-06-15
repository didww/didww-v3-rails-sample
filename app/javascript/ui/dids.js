import onmount from 'onmount'
import ajaxSelect from '../includes/ajax_select'
import remoteForm from '../includes/remote_form'
import encryptFilesManager from '../includes/encrypt_file'
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

const formSelector = '.js-dids-form'
const trunkSelector = `${formSelector} .js-trunk-select select`
const trunkGroupSelector = `${formSelector} .js-trunk-group-select select`
const addressSelector = '#batch-action-address-id'
const batchActionsModalSelector = '.batch-actions-dids'

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
        'batch_action',
        function () {
            // console.log(filesManager.encryptedFiles)
            return filesManager.encryptedFiles
        }
    )
}

// DID can either be assigned to "Voice In" Trunk, or TrunkGroup.
onmount(formSelector, function () {
    $(trunkSelector).change(
        () => $(trunkGroupSelector).val('')
    )
    $(trunkGroupSelector).change(
        () => $(trunkSelector).val('')
    )
})

onmount(addressSelector, function () {
    const addressSelect = $(addressSelector)
    ajaxSelect(addressSelect)
})

onmount('.encrypt-keys-fingerprint', function () {
    const form = $(batchActionsModalSelector).find('form')
    attachRemoteForm(form)
})
