class FlashDecorator < Draper::Decorator

  def msg
    object[1]
  end

  def name
    object[0]
  end

  def css_class
    label = name == :notice ? 'success' : 'danger'
    "alert-#{label}"
  end

  def id
    "flash_#{name}"
  end

end
