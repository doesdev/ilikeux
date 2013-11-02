(function ($, window, document) {

    function boxBuilder() {
        var i, boxes_wrapper, box_width, box_height, colors, border;
        i = 0;
        boxes_wrapper = $("#boxes");
        box_width = boxes_wrapper.outerWidth() / 12 - 10;
        box_height = boxes_wrapper.outerHeight() / 10 - 10;
        boxes_wrapper.empty();
        colors = ["havelock", "malibu", "nevada", "edward", "pomegranate"];

        while (i < 120) {
            border = colors[Math.floor(Math.random() * colors.length)];
            boxes_wrapper.append('<div class="box box-' + border + '"></div>');
            boxes_wrapper.find('.box').css({
                width: box_width,
                height: box_height
            });
            i = i + 1;
        }
    }

    function fontScaling(font_factor) {
        var calculate_font, font_size;
        calculate_font = Math.abs(100 - $(window).outerWidth() / 10) + 100;
        font_size = (calculate_font < font_factor) ? calculate_font : font_factor;
        $('body').css("font-size", font_size + "%");
    }

    function sizing() {
        if ($(window).outerWidth() < 750) {
            fontScaling(90);
        } else {
            fontScaling(125);
        }
    }

    $(window).on("resize", function () {
        sizing();
        boxBuilder();
    });

    $(document).ready(function () {
        sizing();
        boxBuilder();
    });

})(jQuery, window, document);