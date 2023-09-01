public with sharing class InstituteFileController{

    
    public List<String> imageUrls { get; set; }
    public List<String> imageUrlList { get; set; }
    public String image { get; set; }
   
    @AuraEnabled(cacheable=false)
    public static String uploadFile(Id parentId, String fileName, String base64Data) {
        Attachment attachment = new Attachment(
            ParentId = parentId,
            Name = fileName,
            Body = EncodingUtil.base64Decode(base64Data)
        );

        insert attachment;
        
        return attachment.Id;
    }
    public InstituteFileController() {
        imageUrlList = new List<String>();
        imageUrls = populateImageUrls();
        for(integer i = 0;i<imageUrls.size();i++ ){
            if(i == 0){
                image = imageUrls[0];
            }else{
                imageUrlList.add(imageUrls[i]);
            }
        }
         
    }

    // Method to retrieve and populate image URLs from Attachments
    public List<String> populateImageUrls() {
        List<String> imageUrls = new List<String>();
        Institute__c instituteRecord = [SELECT Id FROM Institute__c  LIMIT 1];
        // Replace 'Your_Object_Id_Here' with the actual object Id you want to associate Attachments with
        List<Attachment> attachments = [SELECT Id, Name,ContentType FROM Attachment WHERE ParentId =: instituteRecord.Id ];
        for (Attachment attachment : attachments) {
            String imageUrl ='/servlet/servlet.FileDownload?file=' + attachment.Id;
            imageUrls.add(imageUrl);
        }
        return imageUrls;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getImageUrls(Id parentId) {
        List<Map<String, String>> imageUrls = new List<Map<String, String>>();
        
        // Query Attachments related to the specified ParentId
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :parentId];
        
        for (Attachment attachment : attachments) {
            // Generate the image URL based on Attachment Id
            String imageUrl = '/servlet/servlet.FileDownload?file=' + attachment.Id;
            String fileName = attachment.Name;
            
            // Split the filename into name and extension
            List<String> fileNameParts = fileName.split('\\.');
            String imageName = fileNameParts[0];
            String extension = fileNameParts.size() > 1 ? fileNameParts[1] : '';
            
            // Create a map to hold the image data
            Map<String, String> imageData = new Map<String, String>();
            imageData.put('imageUrl', imageUrl);
            imageData.put('imageName', imageName);
            imageData.put('extension', extension);
            
            // Add the map to the list
            imageUrls.add(imageData);
        }
        
        return imageUrls;
    }

    @AuraEnabled
    public static void deleteImageFile(String imageId) {
        try {
            // Query the Attachment to ensure it exists
            Attachment attachment = [SELECT Id FROM Attachment WHERE Id = :imageId Limit 1];
            
            if (attachment != null) {
                // Delete the Attachment
                delete attachment;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}