//= require includes/utils.js
//= require includes/select_all_logic.js
//= require includes/sku_prices_in_table.js

(function () {

    var buildOrderItemPayload = function ($tr) {
        return {
            available_did_id: $tr.data('available-did-id'),
            sku_id: $tr.find('.js-available-did-sku-select-wrapper > select').val(),
            in: true
        };
    };

    $.onmount('.js-available-dids-refresh', function () {
        var $this = $(this);
        $this.on('click', function () {
            buttonLoadingState($this, true);
            // location.reload(true);
            Turbolinks.visit(location.toString(), {action: 'replace'})
        });
    });

    $.onmount('.js-reserve-did-modal-save', function () {
      $(this).on('click', function () {
        var $this = $(this);
        var $modal = $('.js-reserve-did-modal');
        var availableDidId = $modal.find('input[name="available_did_id"]').val();
        var $tr = $('.js-table-available-dids').find('tr[data-available-did-id="'+availableDidId+'"]')
        var $td = $tr.find('> td:last-child');
        var payload = {
          available_did_id: availableDidId,
          description: $modal.find('input[name="description"]').val()
        };
        buttonLoadingState($this, true);
        $.ajax({
          url: '/did_reservations',
          dataType: 'json',
          method: 'POST',
          data: {did_reservation: payload},
          success: function (data) {
            buttonLoadingState($this, false);
            var link = $('<a>', {href: '/did_reservations/' + data.did_reservation.id}).text('See Reservation');
            $td.empty();
            $td.append(link);
            $modal.modal('hide');
            addFlashMessage('success', ["Reservation was created successfully. ", link.clone()]);
            selectAllLogic.disableRow($tr);
          },
          error: function (error) {
            buttonLoadingState($this, false);
            $modal.modal('hide');
            addFlashMessage('danger', error.responseJSON.error);
          }
        });
      });
    });

    $.onmount('.js-reserve-available-did', function () {
        $(this).on('click', function () {
            var $this = $(this);
            var $tr = $this.closest('tr');
            var $modal = $('.js-reserve-did-modal');
            $modal.find('input[name="description"]').val('');
            $modal.find('input[name="available_did_id"]').val($tr.data('available-did-id'));
            $modal.modal('show');
        });
    });

    $.onmount('.js-order-available-did', function () {
        $(this).on('click', function () {
            var $this = $(this);
            var $tr = $this.closest('tr');
            var $td = $this.closest('td');
            var payload = {
                order: {items_attributes: [buildOrderItemPayload($tr)]}
            };
            buttonLoadingState($this, true);
            $.ajax({
                url: '/orders',
                method: 'POST',
                dataType: 'json',
                data: payload,
                success: function (data) {
                    buttonLoadingState($this, false);
                    var link = $('<a>', {href: '/orders/' + data.order.id}).text('See Order');
                    $td.empty();
                    $td.append(link);
                    addFlashMessage('success', ["Order was created successfully. ", link.clone()]);
                    selectAllLogic.disableRow($tr);
                },
                error: function (error) {
                    buttonLoadingState($this, false);
                    addFlashMessage('danger', error.responseJSON.error);
                }
            });
        });
    });

    $.onmount('.js-available-did-order-selected', function () {
        $(this).on('click', function () {
            var $this = $(this);
            var $selectedRows = $('tbody > tr.selected').toArray();
            var payload = {
                order: {
                    items_attributes: $selectedRows.map(function (tr) {
                        return buildOrderItemPayload($(tr))
                    })
                }
            };
            buttonLoadingState($this, true);
            $.ajax({
                url: '/orders',
                method: 'POST',
                dataType: 'json',
                data: payload,
                success: function (data) {
                    buttonLoadingState($this, false);
                    var link = $('<a>', {href: '/orders/' + data.order.id}).text('See Order');
                    addFlashMessage('success', ["Order was created successfully. ", link]);
                    $selectedRows.forEach(function(row) {
                        var $row = $(row);
                        $row.find('> td:last-child').empty().append(link.clone());
                        selectAllLogic.disableRow($row);
                    });
                    selectAllLogic.unselectAll();

                },
                error: function (error) {
                    buttonLoadingState($this, false);
                    addFlashMessage('danger', error.responseJSON.error);
                }
            });
        });
    });

})();
