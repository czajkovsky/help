class SupportDecorator < Draper::Decorator

  decorates :support
  delegate :done?, :body, :discussed?

  def title
    h.raw "#{receiver} asked #{user} for help."
  end

  def ticket_id
    "##{object.id}"
  end

  def formatted_date(date)
    "#{h.time_ago_in_words(date)} ago"
  end

  def started_at
    formatted_date object.created_at
  end

  def finished_at
    formatted_date object.updated_at
  end

  def comments_label
    return unless object.discussed?
    " &middot; #{h.pluralize(object.comments_count, 'comment')}".html_safe
  end

  def formatted_list_label(params)
    active_user = h.content_tag(:strong, params[:active_user])
    passive_user = h.content_tag(:strong, params[:passive_user])
    "#{active_user} #{params[:action]} #{passive_user} in".html_safe
  end

  def folks_label
    params =  if done?
                { active_user: user, action: 'helped', passive_user: receiver }
              else
                { active_user: receiver, action: 'asked', passive_user: user }
              end
    formatted_list_label params
  end

  def css_class
    done? ? 'done' : date_to_label
  end

  def date_to_label
    case (object.created_at.to_date..Date.today).count
    when 1
      'new'
    when 2..3
      'ok'
    when 4..5
      'worrying'
    else
      'critical'
    end
  end

  def action_button
    return if done? || support.receiver == h.current_user

    if discussed?
      finish_button
    else
      ack_button
    end
  end

  def skip_button
    return if done? || support.user != h.current_user

    h.link_to h.raw('Skip'), h.skip_support_path(object),
              method: :post,
              confirm: "Do you really don't have time for this one?"
  end

  def user
    UserDecorator.decorate(object.user)
  end

  def receiver
    UserDecorator.decorate(object.receiver)
  end

  def topic
    UserDecorator.decorate(object.topic)
  end

  private

  def finish_button
    h.link_to h.raw('Mark as resolved'), h.finish_support_path(object),
      method: :post, class: 'btn btn-success',
      confirm: 'Are you sure you are done helping? This action will also set you as a supporter for this issue.'
  end

  def ack_button
    h.link_to h.raw('Acknowledge!'), h.ack_support_path(object),
      method: :post, class: 'btn btn-success'
  end
end
