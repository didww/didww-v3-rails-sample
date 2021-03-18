import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
    received(data) {
        // console.log('NotificationChannel received', data)
        $.gritter.add({
            title: data.title,
            text: data.message,
            time: 60 * 1000, // 60 seconds
            close_icon: 'l-arrows-remove s16',
            class_name: 'info-notice'
        })
    }
})
