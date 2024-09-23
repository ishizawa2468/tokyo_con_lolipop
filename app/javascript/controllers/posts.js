document.addEventListener('turbolinks:load', function() {
    const imageUpload = document.querySelector('input[type="file"]');
    const currentImageDiv = document.querySelector('.current-image');
    const currentImage = document.querySelector('.thumbnail');
    const removeImageCheckbox = document.querySelector('input[name="post[remove_image]"]');

    if (imageUpload && currentImageDiv && currentImage) {
        imageUpload.addEventListener('change', function(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    currentImage.src = e.target.result;
                    currentImage.style.display = 'block';
                    currentImageDiv.style.display = 'block';
                    if (removeImageCheckbox) {
                        removeImageCheckbox.checked = false;
                    }
                }
                reader.readAsDataURL(file);
            }
        });
    }
});
