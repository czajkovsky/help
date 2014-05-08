class SkipSupport < Struct.new(:support)
  require 'active_support/core_ext/string'

  attr_accessor :candidate, :success
  attr_writer :candidates

  def commence!
    self.success = false
    self.candidate = next_candidate
    if can_skip?
      support.user = candidate
      support.save!
      deliver_email
      self.success = true
    end
    self
  end

  def success?
    success
  end

  def candidates
    @candidates ||= begin
                      users = FindTopicUsers.new support.topic
                      users.all_except support.user
                    end
  end

  private

  def can_skip?
    candidate.present?
  end

  def next_candidate
    candidates.sample
  end

  def deliver_email
    email = SupportMailer.help_me(support)
    email.deliver
  end
end

class FindTopicUsers < Struct.new(:topic)
  def all
    topic.users
  end

  def all_except(user)
    topic.users.without user
  end
end

