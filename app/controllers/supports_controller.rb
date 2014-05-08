class SupportsController < ApplicationController

  expose_decorated(:topic) { Topic.find(params[:topic_id]) }
  expose_decorated(:support) { Support.find(params[:id]) }
  expose_decorated(:comments) { support.comments.includes(:user).order('created_at ASC') }

  def create
    need_support = AskForSupport.new(current_user.object, topic, support_params)
    need_support.commence!

    redirect_to root_path, notice: t('support.create.notice',
                                     name: need_support.supporter)
  end

  def skip
    skip_service = SkipSupport.new support
    skip_service.commence!
    if skip_service.success?
      redirect_to support_path(support), notice: t('support.skip.notice')
    else
      # FIXME: doesn't work with `error: ...` syntax (no flash wrapper)
      redirect_to support_path(support), flash: { error: t('support.skip.error') }
    end
  end

  def ack
    acknowledge_support = AcknowledgeSupport.new current_user.object, support
    acknowledge_support.commence!

    redirect_to support_path(support),
      notice: t('support.ack.notice')
  end

  def finish
    support_finish = FinishSupport.new(current_user.object, support)
    support_finish.commence!
    redirect_to root_path, notice: t('support.finish.notice')
  end

  private

  def support_params
    params.fetch(:support, {}).permit(:body, :user_id)
  end
end
