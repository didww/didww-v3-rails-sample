
/* jshint unused:false */
let initDraggableMultiselect = function ($modal) {
    $modal.find('a[data-action=add]').on('click', function (e) {
        e.preventDefault()
        let $wrapper = $(this).closest('.js-two-way-select'),
            $src = $wrapper.find('.js-src-list'),
            $dst = $wrapper.find('.js-dst-list')
        if ($dst.prop('disabled')) {
            return false
        }
        $src.find('option:selected').appendTo($dst)
    })
    $modal.find('a[data-action=remove]').on('click', function (e) {
        e.preventDefault()
        let $wrapper = $(this).closest('.js-two-way-select'),
            $src = $wrapper.find('.js-src-list'),
            $dst = $wrapper.find('.js-dst-list')
        if ($dst.prop('disabled')) {
            return false
        }
        $dst.find('option:selected').appendTo($src)
    })
    $modal.find('a[data-action=up]').on('click', function (e) {
        e.preventDefault()
        let $wrapper = $(this).closest('.js-two-way-select'),
            $dst = $wrapper.find('.js-dst-list'),
            $prev = $dst.find('option:selected:first').prev()
        if ($dst.prop('disabled')) {
            return false
        }
        if ($prev.length > 0) {
            $dst.find('option:selected').detach().insertBefore($prev)
        }
    })
    $modal.find('a[data-action=down]').on('click', function (e) {
        e.preventDefault()
        let $wrapper = $(this).closest('.js-two-way-select'),
            $dst = $wrapper.find('.js-dst-list'),
            $prev = $dst.find('option:selected:last').next()
        if ($dst.prop('disabled')) {
            return false
        }
        if ($prev.length > 0) {
            $dst.find('option:selected').detach().insertAfter($prev)
        }
    })

    // Mark all options on the right pane of multi-select lists as selected
    $modal.closest('form').submit(function(){
      $(this).find('.js-dst-list').each(function(){
        $(this).find('option').prop('selected', true)
      })
    })

}

export {
    initDraggableMultiselect
}
