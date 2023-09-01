@isTest
public class Test_InstituteFileController {


    @isTest
    public static void testUploadFile() {
        Institute__c testInstitute = new Institute__c(Name = 'Test Institute',Email_id__c='test@dhruvsoft.com',Courses_Offered__c='Doctorate',Billing_Contact_Name__c='BContName', Billing_Email__c='bemail@email.com', Bill_To_Name__c='BName');
        insert testInstitute;

        String fileName = 'testFile.txt';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));

        Test.startTest();
        String attachmentId = InstituteFileController.uploadFile(testInstitute.Id, fileName, base64Data);
        Test.stopTest();

        Attachment attachment = [SELECT Id, Name FROM Attachment WHERE Id = :attachmentId LIMIT 1];
        System.assertEquals(fileName, attachment.Name);
    }

    @isTest
    public static void testGetImageUrls() {
        Institute__c testInstitute = new Institute__c(Name = 'Test Institute',Email_id__c='test@dhruvsoft.com',Courses_Offered__c='Doctorate',Billing_Contact_Name__c='BContName', Billing_Email__c='bemail@email.com', Bill_To_Name__c='BName');
        insert testInstitute;

        Attachment testAttachment = new Attachment(
            ParentId = testInstitute.Id,
            Name = 'testImage.png',
            Body = Blob.valueOf('Test Image Content')
        );
        insert testAttachment;

        Test.startTest();
        List<Map<String, String>> imageUrls = InstituteFileController.getImageUrls(testInstitute.Id);
        Test.stopTest();

        System.assertEquals(1, imageUrls.size());
        Map<String, String> imageData = imageUrls[0];
        System.assertEquals('/servlet/servlet.FileDownload?file=' + testAttachment.Id, imageData.get('imageUrl'));
        System.assertEquals('testImage', imageData.get('imageName'));
        System.assertEquals('png', imageData.get('extension'));
    }

    

    

    @isTest
    public static void testConstructor() {
        Institute__c testInstitute = new Institute__c(Name = 'Test Institute new',Email_id__c='test@dhruvsoft.com',Courses_Offered__c='Doctorate',Billing_Contact_Name__c='BContName', Billing_Email__c='bemail@email.com', Bill_To_Name__c='BName');
        insert testInstitute;

        Attachment testAttachment = new Attachment(
            ParentId = testInstitute.Id,
            Name = 'testImage.png',
            Body = Blob.valueOf('Test Image Content')
        );
        insert testAttachment;
        Test.startTest();
        InstituteFileController controller = new InstituteFileController();
        Test.stopTest();

        System.assertNotEquals(null, controller.imageUrls);
        System.assertNotEquals(null, controller.imageUrlList);
        System.assertNotEquals(null, controller.image);
    }
    
    @isTest
    public static void testDeleteImageFile() {
        Institute__c testInstitute = new Institute__c(Name = 'Test Institute',Email_id__c='test@dhruvsoft.com',Courses_Offered__c='Doctorate',Billing_Contact_Name__c='BContName', Billing_Email__c='bemail@email.com', Bill_To_Name__c='BName');
        insert testInstitute;

        Attachment testAttachment = new Attachment(
            ParentId = testInstitute.Id,
            Name = 'testImage.png',
            Body = Blob.valueOf('Test Image Content')
        );
        insert testAttachment;
       

        Test.startTest();
        InstituteFileController.deleteImageFile(testAttachment.Id);
        try{
        InstituteFileController.deleteImageFile(testAttachment.Id);
        }
        Catch(Exception e){
            
        }
        Test.stopTest();

        List<Attachment> deletedAttachments = [SELECT Id FROM Attachment WHERE Id = :testAttachment.Id];
        System.assertEquals(0, deletedAttachments.size());
    }

    
}