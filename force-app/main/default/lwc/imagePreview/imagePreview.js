import { LightningElement, api } from 'lwc';

export default class ImagePreview extends LightningElement {
    @api imageUrl;
    @api imageName;
    connectedCallback(){
    }
    closePreview() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}
