var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        handleAutofocus(mutation.addedNodes);
    });
});
var target = document.querySelector('body > div');
var config = { childList: true, subtree: true };
observer.observe(target, config);

function handleAutofocus(nodeList) {
    for (var i = 0; i < nodeList.length; i++) {
        var node = nodeList[i];
        if (node instanceof Element && node.hasAttribute('data-autofocus')) {
            node.focus();
            break;
        } else {
            handleAutofocus(node.childNodes);
        }
    }
}

setInterval(function(){
    if (typeof MathJax !== 'undefined')
      MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
}, 1000);
