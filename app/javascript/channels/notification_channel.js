import consumer from "./consumer"

const statusToClass = {
    completed: 'success-notice',
    canceled: 'error-notice'
}
const defaultStatusClass = 'info-notice'

consumer.subscriptions.create("NotificationChannel", {
    received(data) {
        // console.log('NotificationChannel received', data)
        $.gritter.add({
            title: `${ data.type } notification`,
            text: `${ data.type } ${ data.id } is ${ data.status }`,
            time: 60 * 1000, // 60 seconds
            close_icon: 'l-arrows-remove s16',
            class_name: statusToClass[statusToClass[data.status]] || defaultStatusClass
        })
    }
})
