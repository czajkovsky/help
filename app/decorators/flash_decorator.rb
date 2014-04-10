class FlashDecorator < Draper::Decorator

  def msg
    object[1]
  end

  def name
    object[0]
  end

  def css_class
    "alert-#{self.name == :notice ? "success" : "danger"}"
  end

end
