function newNameIsValid() {
    var enteredString = $('#new-collection-name').val();

    // Check if name contains invalid chars
    if (/[^a-zA-Z0-9 ]/.test(enteredString)) {
        return 'non-alphanumeric';
    }
        
    // Check if name already exists
    var res = "ok";
    $('.collection-link').each(function () {
        var col_name = $(this).attr('value');

        if (col_name == enteredString) {
            res = 'already exists';
            return;
        }
    });

    return res;
}
    

$(function () {
    $(document).on('click', '.collection-link', function (event) {
        var $target = $(event.target);
        var classes = $target.attr('class').split(' ');

        while (classes.indexOf('collection-link') === -1) {
            $target = $(event.target);
            classes = $target.attr('class').split(' ');
        }
        collection = $target.attr('value');

        window.location = collection + '/';
    });

    $('#new-collection-name').keyup(function (e) {
        var nameStatus = newNameIsValid();
        if (nameStatus == 'non-alphanumeric') {
            $('#name-form').addClass('has-error');
            $('#name-error').text('Letters, numbers and spaces only, please');
            $('#name-error').removeClass('hidden');
        } else if (nameStatus == 'already exists') {
            $('#name-form').addClass('has-error');
            $('#name-error').text('This name already exists');
            $('#name-error').removeClass('hidden');
        } else {
            $('#name-form').removeClass('has-error');
            $('#name-error').addClass('hidden');
        }
    });

    $('#new-field-name').keyup(function() {
        var newName = $('#new-field-name').val();
        if (/[^a-zA-Z0-9_]/.test(newName)) {
            $('#field-name-error').removeClass('hidden');
            $('#new-field-form').addClass('has-error');
            // TODO CRITICAL dis/enable button here and below
        } else {
            $('#field-name-error').addClass('hidden');
            $('#new-field-form').removeClass('has-error');
        }
    }); 

    // TODO CRITICAL ask for confirmation
    $('.delete-data-button').on('click', function (e) {
        var id = $(this).attr('id');
        var data_uuid_info = id.substring(7);

        window.location = 'delete-data/' + data_uuid_info + '/';
    });

    // TODO CRITICAL clean error classes when value changes
    $('#add-data-form').submit(function( event ) {
        $('.input-field').each(function() {
            var $e = $(this);
            if ($e.hasClass('input-required') && $e.val().length == 0) {
                event.preventDefault();
                var id = $e.attr('id');
                id = id.substring("input-".length);
                $('#error-message-' + id).text('This field is required.');
                $('#error-message-' + id).removeClass('hidden');
                $('#form-group-' + id).addClass('has-error');
                
            }
        });
    });
    
    $('.delete-field-link').click(function(e) {
        var id = $(e.currentTarget).attr('id');
        id = id.substring('delete-'.length);

        // TODO ask for confirmation
        window.location = 'delete-field/' + id + '/';
    });

    // TODO disable add field button when input is invalid or field name already exists

    $('.add-field-button').click(function(e) {
        var id = $(e.currentTarget).attr('id');
        id = id.substring('add-to-'.length);

        // TODO CRITICAL clear old values

        if (id.length === 0) {
            $('#add-to-toplevel-types').removeClass('hidden');
            $('#add-to-list-types').addClass('hidden');
            $('#add-to').val('');
        } else {
            $('#add-to-toplevel-types').addClass('hidden');
            $('#add-to-list-types').removeClass('hidden');
            $('#add-to').val(id.substring(0, id.length-1));
        }
            

        $('#addFieldModal').modal();
    });

    $('#add-field-modal-button').click(function() {
        var add_to = $('#add-to').val();
        var name = $('#new-field-name').val();
        var type, fieldpath;
        if (add_to.length == 0) {
            type = $('#add-to-toplevel-types').val();
            fieldpath = name
        } else {
            type = $('#add-to-list-types').val();
            fieldpath = add_to + '.' + name;
        }

        console.log(add_to);
        console.log(name);
        console.log(type);

        window.location = 'add-field/' + fieldpath + ':' + type + '/';
    });

    $('#delete-collection').click(function() {
        window.location = 'delete/';
    });

    $('.append-to-list-input').keydown(function(e) {
        if (e.keyCode >= 48 && e.keyCode <= 90) {
            var id = $(e.currentTarget).attr('id');
            id = id.substring('append-to-'.length);

            var newFormSnippet = $('#'+id+'-TEMPLATE').clone();
            newFormSnippet.find('input').each(function(i, ele) {
                $(ele).attr('name', $(ele).attr('id'));
            });
            newFormSnippet.removeClass('hidden');
            newFormSnippet.appendTo('#'+id+'-section-inner');
            $('<hr>').appendTo('#'+id+'-section-inner');

            $('#'+id+'-TEMPLATE').find('input').each(function(i, ele) {
                var id = $(ele).attr('id');
                var t = id.split('-');
                var nr = t.pop();
                $(ele).attr('id', t.join('-') + '-' + (parseInt(nr) + 1));
            });

            newFormSnippet.find("input:first").focus();
        }
    });

    $(function () {
        var activeTab = $('[href=' + location.hash + ']');
        activeTab && activeTab.tab('show');
    });

    $('#add-data-form').find('input:first').attr('autofocus', true);
});
