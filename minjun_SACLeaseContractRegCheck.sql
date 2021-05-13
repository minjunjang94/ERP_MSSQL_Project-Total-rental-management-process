IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : üũ
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@Date           NCHAR(8)        -- Date
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Table Ű�� ��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'minjun_TACLeaseContract'
           ,@SeqName    = N'LeaseContSeq'
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContract_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#minjun_TACLeaseContract_' 
    --_SCAOpenXmlToTemp ���� �ӽ� sp�� ����

    IF @@ERROR <> 0 RETURN
    
    
    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #minjun_TACLeaseContract_ WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- �����ڵ�ä�� : ���̺��� �ý��ۿ��� Max������ �ڵ� ä���� ���� �����Ͽ� ä��
        EXEC @Seq = dbo._SCOMCreateSeq @CompanySeq, @TblName, @SeqName, @Count
        
        UPDATE  #minjun_TACLeaseContract_
           SET  LeaseContSeq   = @Seq + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
        
       -- �ܺι�ȣ ä���� ���� ���ڰ�
       SELECT @Date = CONVERT(NVARCHAR(8), GETDATE(), 112)        
       
       -- �ܺι�ȣä�� : ������ �ܺ�Ű�������ǵ�� ȭ�鿡�� ���ǵ� ä����Ģ���� ä��
       EXEC dbo._SCOMCreateNo 'HR', @TblName, @CompanySeq, '', @Date, @MaxNo OUTPUT
       
       UPDATE  #minjun_TACLeaseContract_
          SET  LeaseContNo = @MaxNo
        WHERE  WorkingTag  = 'A'
          AND  Status      = 0
   END
   
    SELECT * FROM #minjun_TACLeaseContract_
    
RETURN