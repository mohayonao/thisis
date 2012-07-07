jQuery(function() {
    var $footer = $("<footer>").css({"margin-top":"15px", "font-size":"0.8em"});
    var $span = $("<span>").text(document.title + " / ");
    var $a    = $("<a>").attr("target", "_blank").css("color", "blue").text("sourcecode");

    var src = "https://github.com/mohayonao/thisis/blob/master/public";
    src += location.pathname
    
    $a.attr("href", src);
    
    $footer.append($span);
    $footer.append($a);
    
    $(document.body).append($footer);
});
