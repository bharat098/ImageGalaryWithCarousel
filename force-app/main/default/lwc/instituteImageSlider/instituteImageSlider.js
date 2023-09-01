import { LightningElement,track, api } from 'lwc';
import uploadFile from '@salesforce/apex/InstituteFileController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getImageUrls from '@salesforce/apex/InstituteFileController.getImageUrls';
import deleteImageFile from '@salesforce/apex/InstituteFileController.deleteImageFile';
export default class InstituteImageSlider extends LightningElement {
    @api recordId; // If you want to associate the attachment with a specific record.
    @track imageData = [];
    fileData;
    imageUrls = [];
    showPreview = false;
    selectedImageUrl;
    @track imageRows = [];
    showPopup=false;
    @track selectedFiles = [];
    imageName;

    handleFileChange(event) {
        this.selectedFiles = event.target.files;
        console.log('this.selectedFiles',this.selectedFiles);
        if (this.selectedFiles.length > 0) {
            this.showPopup = true;
        } else {
            this.showPopup = false;
        }
    }
    removeImage(event) {
        const fileNameToRemove = event.target.dataset.fileName; 
        let tempDelList = [];
        for(let i = 0; i <this.selectedFiles.length; i++ ){
            if(this.selectedFiles[i].name == fileNameToRemove ){
                
            }else{
                tempDelList.push(this.selectedFiles[i]);
            }
        }
        this.selectedFiles = tempDelList;
       
    }
    
    closePopup(){
            this.showPopup=false;
    }
   

    handleUpload() {
        for (let i = 0; i < this.selectedFiles.length; i++) {
            const file = this.selectedFiles[i];
            let reader = new FileReader();
            reader.onloadend = () => {
                let base64data = reader.result.split(',')[1];
                this.imageName = file.name
                this.uploadAttachment(base64data, file.name); // Pass the file name
            };
            reader.readAsDataURL(file);
        }
        }
    

    uploadAttachment(base64data, fileName) {
        // Call the Apex method to create an Attachment
        uploadFile({ parentId: this.recordId, fileName: fileName, base64Data: base64data })
            .then(result => {
                // Handle success
                this.showPopup=false;
                this.loadImages();
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File uploaded successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                // Handle errors
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error uploading file '+fileName,
                        variant: 'error'
                    })
                );
            });
    }

    
    connectedCallback() {
        this.loadImages();
    }

    loadImages() {
        getImageUrls({ parentId: this.recordId })
            .then(result => {
                // Populate imageData array with name and extension data
                this.imageData = result;
            })
            .catch(error => {
            });
    }
    

    closePreview() {
        this.showPreview = false;
    }
    deleteImage(event) {
        const imageId = event.target.value;
        const parts = imageId.split('?file=');
        if (parts.length === 2) {
            const fileId = parts[1]; 
        deleteImageFile({ imageId: fileId})
            .then(() => {
                // Reload the image gallery after deleting the image
                this.loadImages();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Image deleted successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error deleting image',
                        variant: 'error'
                    })
                );
            });
        }
        
    }
    get iconName() {
        // Update iconName based on the extension
        const extension = this.selectedFiles.Extension;
        if (extension === "pdf") {
            return "doctype:pdf";
        }
        // Add other extensions as needed
        // ...
        return "doctype:image";
    }

      handleFileItemClick(event) {
        this.selectedImageUrl = event.currentTarget.dataset.imageurl;
        this.selectedImageName =event.currentTarget.dataset.imagetext;

        // Check if the clicked element or its parent elements contain the dropdown button
        if (!event.target.closest('lightning-button-menu')) {
          // Click is not on the dropdown or its children, so call filePreview()
          this.showPreview = true;
        }
      }
}
