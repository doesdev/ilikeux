(function ($, window, document) {

    function boxesText() {
        var sentence;
        sentence = ["this", "is", "just", "an", "excuse", "to", "play", "around", "with", "js"];
        $(".box").each(function (i) {
            if (i % 10 === 0) {
                $(this).append('<p>' + sentence[i.toString().charAt(0)] + '</p>');
            }
        });
    }

    function boxBuilder() {
        var i, boxes_wrapper, wrapper_height, box_width, box_height, colors, border;
        i = 0;
        boxes_wrapper = $("#boxes");
        wrapper_height = boxes_wrapper.outerHeight() - ($("header").outerHeight() + 4);
        box_width = boxes_wrapper.outerWidth() / 10 - 10;
        box_height = wrapper_height / 10 - 10;
        boxes_wrapper.empty();
        colors = ["havelock", "malibu", "nevada", "edward", "pomegranate"];

        while (i < 100) {
            border = colors[Math.floor(Math.random() * colors.length)];
            boxes_wrapper.append('<div class="box box-' + border + '"></div>');
            boxes_wrapper.find('.box').css({
                width: box_width,
                height: box_height
            });
            i = i + 1;
        }
        boxesText();
    }

    function boxesStart() {
        $("#boxes").css("top", ($("header").outerHeight() + 8) + "px");
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
        boxesStart();
        boxBuilder();
    }

    $(window).on("resize", function () {
        sizing();
    });

    $(document).ready(function () {
        sizing();
    });

})(jQuery, window, document);