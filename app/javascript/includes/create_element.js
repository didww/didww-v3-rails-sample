function createElement(tagName, options, children) {
    if(!options) options = {}
    if (!children) children = ''
    const node = $(`<${tagName}>`, options)
    if (Array.isArray(children)) node.html(children.join("\n"))
    if (typeof children === 'string') node.text(children)
    return node[0].outerHTML
}

export default createElement
