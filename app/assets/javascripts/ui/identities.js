//= require ../includes/remote_form
//= require ../includes/encrypt_file

$(document).ready(function () {

    function attachRemoteForm(form) {

        var filesManager = window.encryptFilesManager({
            onEmpty: function (input) {
                inputSetState(input, '');
            },
            onEncryptionStart: function (input) {
                inputSetState(input, 'Encrypting...');
            },
            onEncryptionEnd: function (input) {
                inputSetState(input, 'Encrypted.');
            }
        });

        function inputSetState(input, text) {
            var status = input.siblings('.file-input-status');
            if (status.length === 0) {
                input.parent().append(
                    $('<span>', { class: 'file-input-status' })
                );
                status = input.siblings('.file-input-status').css({ marginLeft: '5px' });
            }

            status.html('');
            status.append(text);
        }

        window.remoteForm(
            form,
            'add_proof',
            function () {
                return filesManager.encryptedFiles;
            }
        );

        $('#add-proof-modal').on('show.bs.modal', function (e) {
            filesManager.setFingerprint(form);
        })

        $('#add-proof-modal').on('hide.bs.modal', function (e) {
            $(form)[0].reset()
        })

        $.each($('.has_many_container.proofs input[type="file"]'), function () {
            filesManager.addInput($(this));
        });

        $(document).on('has_many_add:after', '.has_many_container.proofs', function (event, fieldset) {
            var input = fieldset.find('input[type="file"]');
            filesManager.addInput(input);
        });

        $(document).on('has_many_remove:before', '.has_many_container.proofs', function (event, fieldset) {
            var input = fieldset.find('input[type="file"]');
            var inputName = input.attr('data-name');
            filesManager.removeInput(inputName);
        });
    }

    var form = $('#add_proof, #replace_proof');

    if (form.length > 0) {
        console.log(form)
        attachRemoteForm(form);
    }

});
