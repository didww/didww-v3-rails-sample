import DidwwEncrypt from '@didww/encrypt'

function getV3ApiBaseURL() {
    return document.querySelector('meta[name=v3_api_base_url]').content
}

function encryptFilesManager(options) {
    var fileReaders = {}
    var encryptedFiles = {}
    var encryptor = new DidwwEncrypt({
        url: `${ getV3ApiBaseURL() }/public_keys`
    })

    function findInput(inputName) {
        return $('input[data-name="' + inputName + '"]')
    }

    function addEncryptedFile(inputName, encryptedFile) {
        if (encryptedFiles[inputName] === undefined) {
            // console.log('addEncryptedFile fieldset already deleted', inputName)
            return
        }

        var input = findInput(inputName)
        if (input.length > 0 && !input.attr('disabled')) {
            encryptedFiles[inputName].push(encryptedFile)

            if (encryptedFiles[inputName].length === input[0].files.length && options.onEncryptionEnd) {
                options.onEncryptionEnd(input)
            }
        }
    }

    function encryptFile(inputName, file, index) {
        var reader = new FileReader()
        fileReaders[inputName][index] = reader
        reader.onload = function () {
            var currentReader = fileReaders[inputName][index]
            if (!currentReader) {
                return
            }

            var buffer = currentReader.result
            encryptor.encrypt(buffer).then(function (encrypted) {
                var encryptedFile = encrypted.toFile()
                addEncryptedFile(inputName, encryptedFile)
            })
        }
        reader.onerror = function () {
            console.error('FileReader Error ' + inputName, reader.error)
        }
        reader.readAsArrayBuffer(file)
    }

    function handleInputChange(event) {
        var input = $(event.target)
        var inputName = input.attr('data-name')
        // console.log('encrypt handleInputChange', inputName, input)

        encryptedFiles[inputName] = []
        fileReaders[inputName] = {}
        var rawFiles = input[0].files

        if (rawFiles.length === 0) {
            if (options.onEmpty) {
                options.onEmpty(input)
            }
            return
        }

        if (options.onEncryptionStart) {
            options.onEncryptionStart(input)
        }

        for (let i = 0; i < rawFiles.length; i++) {
            encryptFile(inputName, rawFiles[i], i)
        }
    }

    function addInput(input) {
        // console.log('encrypt add input', input)
        if (input.length === 0) {
            return
        }

        input.on('change', handleInputChange)
        input.val('')
    }

    function removeInput(inputName) {
        delete encryptedFiles[inputName]
        delete fileReaders[inputName]

        var input = findInput(inputName)
        if (input.length === 0) {
            return
        }

        input.attr('name', inputName)
        input.removeAttr('data-name')
        input.off('change', handleInputChange)
        input.val('')
    }

    function setFingerprint(form) {
        encryptor.getFingerprint().then(function (fingerprint) {
            // console.log('fingerprint', fingerprint)
            form.find('.encrypt-keys-fingerprint').val(fingerprint)
        })
    }

    function getFingerprint() {
        return encryptor.getFingerprint()
    }

    return {
        fileReaders: fileReaders,
        encryptedFiles: encryptedFiles,
        addInput: addInput,
        removeInput: removeInput,
        setFingerprint: setFingerprint,
        getFingerprint: getFingerprint
    }
}

export default encryptFilesManager
