class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  default_scope { order(created_at: :desc) }


  after_create_commit { broadcast_prepend_to("comments", locals: { from_stream: true }) }
  after_create_commit { broadcast_replace_to("comments_counter", target: "comments_counter", partial: "comments/counter", locals: { commentable: commentable }) }

  after_update_commit { broadcast_replace_to("comments", target: "comment_#{id}", partial: "comments/comment", locals: { from_stream: true }) }

  after_destroy_commit { broadcast_remove_to("comments", target: "comment_#{id}") }
  after_destroy_commit { broadcast_replace_to("comments_counter", target: "comments_counter", partial: "comments/counter", locals: { commentable: commentable }) }
end
