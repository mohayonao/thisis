jQuery(function() {
    var $footer = $("<footer>").css({"position":"absolute",
                                     "bottom":"10px", "left":"10px"});

    var $span = $("<span>").text(document.title + " / ");
    var $a    = $("<a>").attr("target", "_blank").css("color", "blue").text("view this source");

    var src = "https://github.com/mohayonao/thisis/blob/master/public";
    src += location.pathname
    
    $a.attr("href", src);
    
    $footer.append($span);
    $footer.append($a);
    
    $(document.body).append($footer);
});
