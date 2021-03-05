//= require ../vendor/didww-encrypt

(function () {

    function encryptFilesManager(options) {
        var fileReaders = {};
        var encryptedFiles = {};
        var encryptor = new DidwwEncrypt({
            url: 'http://127.0.0.1:4000'
        });

        function findInput(inputName) {
            return $('input[data-name="' + inputName + '"]');
        }

        function addEncryptedFile(inputName, encryptedFile) {
            if (encryptedFiles[inputName] === undefined) {
                // console.log('addEncryptedFile fieldset already deleted', inputName);
                return;
            }

            var input = findInput(inputName);
            if (input.length > 0 && !input.attr('disabled')) {
                encryptedFiles[inputName].push(encryptedFile);

                if (encryptedFiles[inputName].length === input[0].files.length && options.onEncryptionEnd) {
                    options.onEncryptionEnd(input);
                }
            }
        }

        function encryptFile(inputName, file, index) {
            var reader = new FileReader();
            fileReaders[inputName][index] = reader;
            reader.onload = function () {
                var currentReader = fileReaders[inputName][index];
                if (!currentReader) {
                    return;
                }

                var content = currentReader.result;
                encryptor.encryptContent(content).then(function (encrypted) {
                    var encryptedFile = encrypted.toFile();
                    addEncryptedFile(inputName, encryptedFile);
                });
            };
            reader.onerror = function () {
                console.error('FileReader Error ' + inputName, reader.error);
            };
            reader.readAsDataURL(file);
        }

        function handleInputChange(event) {
            var input = $(event.target);
            var inputName = input.attr('data-name');

            encryptedFiles[inputName] = [];
            fileReaders[inputName] = {};
            var rawFiles = input[0].files;

            if (rawFiles.length === 0) {
                if (options.onEmpty) {
                    options.onEmpty(input);
                }
                return;
            }

            if (options.onEncryptionStart) {
                options.onEncryptionStart(input);
            }

            for (var i = 0; i < rawFiles.length; i++) {
                encryptFile(inputName, rawFiles[i], i);
            }
        }

        function addInput (input) {
            if (input.length === 0) {
                return;
            }

            var inputName = input.attr('name');
            // regulation_identity[proofs_attributes][0][files]
            // remoteForm will add '[]' to the end of inputName on submit.
            if (inputName.substring(inputName.length - 2, inputName.length) === '[]') {
                inputName = inputName.substring(0, inputName.length - 2);
            }
            input.attr('data-name', inputName);
            input.removeAttr('name');

            input.on('change', handleInputChange);
            input.val('');
        }

        function removeInput (inputName) {
            delete encryptedFiles[inputName];
            delete fileReaders[inputName];

            var input = findInput(inputName);
            if (input.length === 0) {
                return;
            }

            input.attr('name', inputName);
            input.removeAttr('data-name');
            input.off('change', handleInputChange);
            input.val('');
        }

        function setFingerprint (form) {
            encryptor.getFingerprint().then(function (fingerprint) {
                // console.log('fingerprint', fingerprint);
                form.find('.encrypt-keys-fingerprint').val(fingerprint);
            });
        }

        return {
            fileReaders: fileReaders,
            encryptedFiles: encryptedFiles,
            addInput: addInput,
            removeInput: removeInput,
            setFingerprint: setFingerprint
        };
    }

    window.encryptFilesManager = encryptFilesManager;
})();
