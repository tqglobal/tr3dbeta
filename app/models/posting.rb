# A Page is a blogabble semi-static content-item.
# If <code>show_in_menu</code> the page will have a link in the
# application menu.
# Pages can be addressed by <code>/pages/OBJECT_ID</code> or
# <code>/p/TITLE_OF_THE_PAGE</code>. It can have comments and a 'cover-picture'
class Posting 
  include ContentItem
  acts_as_content_item
  has_cover_picture
  
  # Fields ======================================================
  referenced_in         :user, :inverse_of => :postings
  field                 :user_id  
  validates_presence_of :user_id
  
  field                 :body, :required => true
  validates_presence_of :body

  field                 :interpreter, :default => :markdown  
  
  # Associations  ================================================
  referenced_in         :blog, :inverse_of => :postings

  references_many       :comments, :inverse_of => :commentable
  validates_associated  :comments
  
  # TODO: Move this definitions to a library-module
  # TODO: and replace this lines with just 'has_attchments'
  embeds_many           :attachments
  validates_associated  :attachments
  accepts_nested_attributes_for :attachments,
                                :allow_destroy => true
                        
  # Send notifications
  after_create  :send_notifications
    
  # Render the body with RedCloth
  def render_body
    render_for_html(self.body)
  end
    
  private ################################################## private ####
  
  # Render the intro (which is the first paragraph of the body)
  def content_for_intro
    render_for_html(body.paragraphs[0])
  end

  # Send a notification to admins when a new posting was created
  def send_notifications
    DelayedJob.enqueue('NewPostingNotifier', 
      Time.now + (CONSTANTS['delay_comment_notifications'].to_i).seconds,
      self.blog.id, self.id
    )
  end  

end
