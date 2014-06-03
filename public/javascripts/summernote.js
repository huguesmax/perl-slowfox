
$("#EnregisterAction").click(function(e)e
                        var Thedata= $("#summernote").serialize();

                        $.post(urlform,Thedata,function(data){
                                window.location = "/recouvrement/summernote/";
                        });

});
                       

