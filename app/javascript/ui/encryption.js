import onmount from 'onmount'
import encryptFilesManager from "../includes/encrypt_file";

const fileInputSelector = '#encrypt-file'
const fingerprintSelector = '#encryption-fingerprint'
const fileInputStatusSelector = '#encrypt-file-status'
const downloadLinkSelector = '#encrypted-download-link'
const clearBtnSelector = '#encrypt-file-clear-btn'

function buildDownloadLink (file, filename) {
    const blobUrl = URL.createObjectURL(file)
    return $('<a>', { download: filename, href: blobUrl })
        .text('Download ' + filename)
        .css({ display: 'block' })
}

onmount(fileInputSelector, function () {
    const fileInput = $(fileInputSelector)
    const fileInputStatus = $(fileInputStatusSelector)
    const fingerprintSpan = $(fingerprintSelector)
    const downloadContainer = $(downloadLinkSelector)
    const clearBtn = $(clearBtnSelector)

    clearBtn.on('click', () => {
        fileInput.val('')
        fileInput.trigger('change')
    })

    const filesManager = encryptFilesManager({
        onEmpty: function () {
            fileInputStatus.text('')
            downloadContainer.html('')
        },
        onEncryptionStart: function () {
            fileInputStatus.text('Encrypting...')
        },
        onEncryptionEnd: function () {
            fileInputStatus.text('Encrypted.')
            downloadContainer.html('')
            filesManager.encryptedFiles['files'].forEach((file, index) => {
                const originalFile = fileInput[0].files[index]
                const filename = `${ originalFile.name }.enc`
                const link = buildDownloadLink(file, filename)
                downloadContainer.append(link)
            })
        }
    })
    filesManager.addInput(fileInput)
    filesManager.getFingerprint().then(fingerprint => {
        fingerprintSpan.text(fingerprint)
    })
})
